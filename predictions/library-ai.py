# ============================================
# Final Code: Library Management AI - Neural Network Prediction
# ============================================

import os
import sqlite3
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.optimizers import Adam

# ============================================
# STEP 0: Automatically create database from main.sql
# ============================================
DB_PATH = "library.db"  # The database file will be created here

# Check if main.sql exists in the same folder
if os.path.exists("main.sql"):
    print("✅ Found main.sql. Building the database...")
    try:
        conn = sqlite3.connect(DB_PATH)
        with open("main.sql", "r", encoding="utf-8") as f:
            sql_script = f.read()
        conn.executescript(sql_script)
        conn.commit()
        conn.close()
        print("✅ Database successfully created from main.sql")
    except Exception as e:
        print(f"❌ Error creating database: {e}")
        exit()
else:
    print("⚠️ main.sql not found. Assuming database already exists.")

# ============================================
# STEP 1: Connect to Database
# ============================================
try:
    conn = sqlite3.connect(DB_PATH)
    print("✅ Successfully connected to the database")
except Exception as e:
    print(f"❌ Connection error: {e}")
    exit()

# ============================================
# STEP 2: Extract Data using SQL Query (JOIN)
# ============================================
query = """
SELECT 
    Loans.LoanID,
    Loans.MemberID,
    Loans.BookID,
    Loans.LoanDate,
    Loans.Status,
    julianday('now') - julianday(Loans.LoanDate) AS DaysSinceLoan,
    Books.AvailableCopies,
    Books.Category,
    Authors.Country,
    CASE 
        WHEN Authors.Country = 'Iran' THEN 0 
        WHEN Authors.Country = 'England' THEN 1 
        ELSE 2 
    END AS CountryCode,
    CASE 
        WHEN Loans.Status = 'Overdue' THEN 1 
        ELSE 0 
    END AS Label
FROM Loans
JOIN Books ON Loans.BookID = Books.BookID
JOIN Authors ON Books.AuthorID = Authors.AuthorID
"""

df = pd.read_sql_query(query, conn)
conn.close()

print(f"\n• Data shape: {df.shape}")
print("\n• First few rows:")
print(df.head())

# ============================================
# STEP 3: Feature Engineering
# ============================================

# One-Hot Encoding for Category
category_dummies = pd.get_dummies(df['Category'], prefix='Cat')
df = pd.concat([df, category_dummies], axis=1)

# Select numerical features for neural network input
feature_columns = [
    'DaysSinceLoan',      # Days passed since loan
    'AvailableCopies',    # Number of available copies
    'CountryCode',        # Author's country code (0=Iran, 1=England)
]

# Add category dummy columns
for col in category_dummies.columns:
    feature_columns.append(col)

X = df[feature_columns].values  # Features (input)
y = df['Label'].values          # Target (1=Overdue, 0=Other)

print(f"\n• Number of samples: {len(X)}")
print(f"• Number of features: {X.shape[1]}")
print(f"• Number of Overdue samples: {sum(y)} out of {len(y)}")

# ============================================
# STEP 4: Split Data into Training and Testing
# ============================================
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42, stratify=y
)

print(f"\n• Training data: {X_train.shape[0]} samples")
print(f"• Testing data: {X_test.shape[0]} samples")

# Normalize the data
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# ============================================
# STEP 5: Build the Neural Network
# ============================================
model = Sequential([
    Dense(16, activation='relu', input_shape=(X_train.shape[1],)),
    Dropout(0.2),                    # Prevents overfitting
    Dense(8, activation='relu'),
    Dropout(0.2),
    Dense(4, activation='relu'),
    Dense(1, activation='sigmoid')   # Output between 0 and 1 for binary classification
])

# Compile the model
model.compile(
    optimizer=Adam(learning_rate=0.01),
    loss='binary_crossentropy',
    metrics=['accuracy']
)

print("\n• Neural Network Architecture:")
model.summary()

# ============================================
# STEP 6: Train the Network
# ============================================
print("\n• Starting training...")
history = model.fit(
    X_train, y_train,
    epochs=50,                    # Number of training cycles
    batch_size=4,                 # Batch size
    validation_split=0.2,         # 20% of training data for validation
    verbose=1
)

# ============================================
# STEP 7: Evaluate on Test Data
# ============================================
test_loss, test_acc = model.evaluate(X_test, y_test, verbose=0)
print(f"\n• Test Accuracy: {test_acc:.2%}")
print(f"• Test Loss: {test_loss:.4f}")

# ============================================
# STEP 8: Make Predictions on All Data
# ============================================
X_all = scaler.transform(df[feature_columns].values)
predictions_prob = model.predict(X_all)
predictions_binary = (predictions_prob > 0.5).astype(int)

# Add predictions to dataframe
df['Predicted_Overdue_Prob'] = predictions_prob
df['Predicted_Overdue_Class'] = predictions_binary

print("\n• Prediction results (first 5 rows):")
print(df[['LoanID', 'Status', 'Predicted_Overdue_Prob', 'Predicted_Overdue_Class']].head())

# ============================================
# STEP 9: Save Results to Database
# ============================================
conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

# Create new table for storing predictions
cursor.execute("""
CREATE TABLE IF NOT EXISTS LoanPredictions (
    PredictionID INTEGER PRIMARY KEY AUTOINCREMENT,
    LoanID INTEGER,
    PredictedOverdueProbability REAL,
    PredictedOverdueClass INTEGER,
    PredictionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
)
""")

# Clear previous records (optional)
cursor.execute("DELETE FROM LoanPredictions")

# Insert new predictions
for idx, row in df.iterrows():
    cursor.execute("""
    INSERT INTO LoanPredictions (LoanID, PredictedOverdueProbability, PredictedOverdueClass)
    VALUES (?, ?, ?)
    """, (int(row['LoanID']), float(row['Predicted_Overdue_Prob']), int(row['Predicted_Overdue_Class'])))

conn.commit()
print(f"\n• Predictions saved to 'LoanPredictions' table ({len(df)} records)")

# ============================================
# STEP 10: Final Report
# ============================================
print("\n" + "="*60)
print("• FINAL REPORT")
print("="*60)

report_query = """
SELECT 
    lp.LoanID,
    m.FirstName || ' ' || m.LastName AS MemberName,
    b.Title AS BookTitle,
    l.Status AS ActualStatus,
    lp.PredictedOverdueClass AS PredictedIsOverdue,
    round(lp.PredictedOverdueProbability, 3) AS Confidence
FROM LoanPredictions lp
JOIN Loans l ON lp.LoanID = l.LoanID
JOIN Members m ON l.MemberID = m.MemberID
JOIN Books b ON l.BookID = b.BookID
ORDER BY lp.PredictionDate DESC
"""

report_df = pd.read_sql_query(report_query, conn)
print(report_df.to_string(index=False))

conn.close()
print("\n✅ All operations completed successfully.")
