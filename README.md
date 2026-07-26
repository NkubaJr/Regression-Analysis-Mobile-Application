# Art Auction Price Prediction

## Mission
This project predicts the auction sale price of an artwork from its creation
year, signing status, condition, artist recognition, period, and movement, so
galleries and buyers can sanity-check listing prices against market data.

## Dataset
Source: [Art Price Dataset](https://www.kaggle.com/datasets/flkuhm/art-price-dataset)
on Kaggle (`flkuhm/art-price-dataset`). 754 real auction records with price,
artist, title, creation year, signing status, condition, period, and movement.

## Public API (Swagger UI)
**Live endpoint:** https://art-price-api.onrender.com/docs

- `POST /predict` — returns predicted auction price (USD) for an artwork.
- `POST /retrain` — upload new labeled CSV data to retrain and hot-swap the model.
- Inputs are validated with Pydantic (enforced datatypes and realistic ranges).

Note: the free Render tier spins down after ~15 minutes of inactivity; the
first request after idle may take 30-60 seconds to respond.

## Video Demo
YouTube: https://youtu.be/M5pc0WcTHDs

## Model Performance
Test-set metrics (log-transformed price), from `summative/linear_regression/multivariate.ipynb`:

| Model                       | Train MSE | Test MSE | Test R² |
|------------------------------|-----------|----------|---------|
| **Random Forest**            | 0.199     | **0.652**| 0.552   |
| Decision Tree                 | 0.461     | 0.841    | 0.422   |
| Linear Regression (OLS)       | 0.995     | 1.197    | 0.178   |
| SGD Regressor (stochastic)    | 1.096     | 1.228    | 0.157   |

Random Forest was selected as the best-performing model (lowest test MSE) and
is the model saved and served by the API.

## Running the Mobile App

**Option 1 — Install the pre-built APK (fastest, no setup required):**
[Download APK](PASTE_GOOGLE_DRIVE_LINK_HERE) and install directly on an Android device.

**Option 2 — Run from source:**
1. Install Flutter (https://docs.flutter.dev/get-started/install) and confirm
   your setup with `flutter doctor`.
2. From the repo root:
   ```
   cd summative/FlutterApp
   flutter pub get
   ```
3. Start an Android emulator (via Android Studio's Device Manager) or connect
   a physical Android device with USB debugging enabled, then run:
   ```
   flutter run
   ```
4. The app already points at the live API
   (`https://art-price-api.onrender.com`), so no configuration is needed.
   Fill in the artwork details and tap **Predict** to get an estimated price.

## Package & Environment Management — uv
This project uses [uv](https://docs.astral.sh/uv/) for Python dependency and
virtual environment management.

```
# install uv if you don't have it
pip install uv

# from the repo root — creates .venv and installs everything from uv.lock
uv sync

# run the notebook
uv run jupyter notebook summative/linear_regression/multivariate.ipynb

# run the API locally
uv run uvicorn summative.API.prediction:app --reload --port 8000
```

## Repository Structure
```
Regression-Analysis-Mobile-Application/
├── pyproject.toml                          # uv-managed dependencies
├── uv.lock                                 # locked dependency versions
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb              # EDA, feature engineering, 4-model comparison
│   │   ├── artDataset.csv                  # raw dataset
│   │   ├── best_model.joblib               # best-performing model (Random Forest)
│   │   ├── scaler.joblib                   # fitted StandardScaler
│   │   ├── feature_columns.joblib          # exact training feature column order
│   │   ├── known_movements.joblib          # valid movement categories
│   │   └── known_periods.joblib            # valid period categories
│   ├── API/
│   │   ├── prediction.py                   # FastAPI app: /predict, /retrain, CORS, Pydantic
│   │   └── requirements.txt
│   └── FlutterApp/
│       ├── pubspec.yaml
│       ├── lib/main.dart                   # single-page app: 6 inputs, Predict button, result/error area
│       └── README.md
```
