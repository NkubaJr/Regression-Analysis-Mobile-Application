# Art Auction Price Prediction

## Mission
This project predicts the auction sale price of an artwork from its creation
year, signing status, condition, artist recognition, period, and movement, so
galleries and buyers can sanity-check listing prices against market data.

## Dataset

Source: Art Price Dataset on Kaggle (flkuhm/art-price-dataset). 754 real auction records with price, artist, title, creation year, signing status, condition, period, and movement.

## API
- Swagger UI: https://art-price-api.onrender.com/docs
- Predict endpoint: `POST https://art-price-api.onrender.com/predict`
- Retrain endpoint: `POST https://art-price-api.onrender.com/retrain`

Note: the free Render tier spins down after ~15 minutes of inactivity; the
first request after idle may take 30-60 seconds to respond.

## Demo Video
(link coming after Task 4)

## Running the Flutter App

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
