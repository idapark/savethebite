# SaveTheBite

<img width="258" alt="image" src="https://github.com/user-attachments/assets/5acfe8db-a2ab-42bb-b577-d1d3a5390e64">


## Overview
SaveTheBite is an iOS application designed to help users manage their grocery items more efficiently by maming sure that the food does not expire. It features barcode scanning, text recognition for expiration dates, and a user-friendly interface for organizing items by date. This was my first application I made using Swift as a part of a project course during my bachelor's studies fall 2023, where I chose to learn Swift programming.

## Features
- Barcode Scanning: Users can scan both the barcode and expiration date using the device's camera.
- Manual Entry: For items without a barcode or with unreadable barcodes, users can input the barcode number and expiration date manually.
- CoreData integration for persistent storage of item data.
- Custom user interface for managing and displaying items.
- Navigation and UI customization with dynamic color themes depending on the expiration date.
- Sheet View & Multiple Views: The app supports a sheet view for adding items via camera and manual input, along with multiple views for product fetching and entry.
- Supporting animations for enhanced user experience.

## Installation

### Prerequisites
- **XCode 12** or later
- **iOS 14** or later
- **Swift 5**

### Steps
1. Clone the repository from GitLab.
2. Open the project in XCode.
3. Install any required dependencies.
4. Build and run the application on a compatible iOS device or simulator.
   - Ensure that your Apple ID is configured to support app installation.

### Dependencies
- **Lottie**: [Lottie iOS](https://github.com/airbnb/lottie-ios) (can be installed using Package Manager or CocoaPods).
- **SwiftGif**: (included in the repository).

<div style="display: flex; justify-content: center; gap: 10px;">
    <img width="300" alt="image" src="https://github.com/user-attachments/assets/7df2be06-1640-4600-b52c-584a828a4aea">
    <img width="300" alt="image" src="https://github.com/user-attachments/assets/87cd4e17-4972-4a0d-84ef-b93fc1d0bd2f">
    <img width="300" alt="image" src="https://github.com/user-attachments/assets/085cfb02-e50e-445b-8db9-44b824b33de4">
    <img width="300" alt="image" src="https://github.com/user-attachments/assets/71a0d983-9ea6-45fb-b508-c078763d3497">
    <img width="300" alt="image" src="https://github.com/user-attachments/assets/0874cc03-7ee0-42a4-bedc-4a3d880416cc">
</div>





## Usage

### Adding Items
- Use the 'Add Item' button to open the camera and scan the barcode of an item.
- For items without a barcode or with unreadable barcodes, use the 'Add Manually' option.

### Viewing Items
- Items are displayed in a table view, organized by their expiration dates.
- Expired items are highlighted for easy identification.

### Managing Items
- Swipe to delete items as needed.

## Key Components
- **AppDelegate**: Manages core application lifecycle events.
- **ItemManager**: Handles creation, addition, and deletion operations for item data using CoreData, ensuring data persistence.
- **DetectTextManager**: Implements text recognition to extract expiration dates from product packaging.
- **DetectBarcodeManager**: Provides barcode scanning functionality.
- **ProductFetcher**: Fetches product data from the OpenFoodFacts API.
- **TableViewController**: The main interface for displaying and managing items.
- **CustomSheetViewController**: Manages the UI for barcode and expiration date scanning.

## Customization
- Modify `ColoursManager` to change the application’s color theme.
- Update `CustomTableViewCell` for custom cell layouts.

## Future Improvements
- Fix deletion method: Currently, deleting the first item removes the last item due to CoreData indexing issues.
- Fix date method: Currently, sometimes depending on the format of the input date the date might be incorrect.
- Add an animation when manually adding items (currently only appears for barcode scanning).
- Implement notification functionality.
- Display more item information when pressed (e.g., allergens, nutritional information).
- Add more interactive elements.
- Support light and dark modes (currently, both modes use the same colors).
- Clean up the `Controls` folder and organize methods into the `Models` and `Views` folders.

## Acknowledgments
- **Icons** provided by [Icons8](https://icons8.com/icons/set/checkmark--animated).
- **Illustrations** by Elisabet Guba from [Ouch!](https://icons8.com/illustrations/illustration/techny-shopping-basket-full-of-groceries--animated).
- **OpenFoodFacts** API used for product data: [OpenFoodFacts](https://world.openfoodfacts.org).
- **SwiftGif**: [SwiftGif](https://github.com/swiftgif/SwiftGif/blob/master/SwiftGifCommon/UIImage%2BGif.swift).
