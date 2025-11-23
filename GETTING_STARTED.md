# Getting Started with Organizer App

## Quick Start Guide

### Prerequisites
✅ Flutter SDK installed  
✅ Android Studio or VS Code with Flutter extensions  
✅ A device or emulator ready to run

### Running the App

1. **Navigate to the project directory:**
   ```bash
   cd Documents/Organizer
   ```

2. **Verify Flutter setup:**
   ```bash
   flutter doctor
   ```

3. **Get dependencies (already done, but just in case):**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

5. **Choose your device when prompted**

## First Time Setup

### Create Your First List
1. Launch the app
2. You'll see an empty state with "No lists yet"
3. Tap the **orange floating action button (+)** at the bottom right
4. Enter a list name (e.g., "Christmas Ornaments")
5. Optionally add a description
6. Tap **"Create"**

### Add Your First Item
1. Tap on your newly created list
2. Tap the **floating action button (+)**
3. Add a photo:
   - Tap **"Add Photo"**
   - Choose **"Take Photo"** (camera) or **"Choose from Gallery"**
   - Take/select a photo of your item
4. Fill in the details:
   - **Name**: Give your item a name (required)
   - **Description**: Add details (optional)
   - **Type**: Category like "ornament", "vase", "decor" (required)
   - **Acquisition**: Choose "Bought" or "Gift"
   - **Year**: When you got it (required)
   - **Value**: Price if bought (optional, hidden for gifts)
5. Tap **"Save"**

### View Item Details
1. In your list, tap any item card
2. Swipe left/right if you have multiple photos
3. View all details like type, year, value, etc.
4. Tap the **edit icon** to modify
5. Tap the **menu (⋮)** to delete

## Features Overview

### ✅ Currently Working

#### List Management
- Create multiple lists for different categories
- Edit list names and descriptions
- Delete lists (deletes all items in the list)
- View item count for each list

#### Item Management
- Add items with photos from camera or gallery
- Add multiple photos per item
- Edit all item details
- Delete items
- Mark items as Bought or Gift
- Track year acquired and value

#### Organization
- Sort items by name (A-Z, Z-A)
- Sort items by date (newest/oldest)
- View statistics on home screen
- Pull to refresh lists

#### User Interface
- Modern, clean design
- Beautiful card layouts
- Smooth animations
- Empty states with helpful messages
- Loading indicators
- Confirmation dialogs for destructive actions

### 🚧 Coming Soon (Not Yet Implemented)

#### AI-Powered Duplicate Detection
- Take a photo in a store
- AI checks if you already own it
- See similar items in your collection
- Prevent duplicate purchases

#### Search & Filter
- Global search across all items
- Filter by type, year, value
- Advanced filtering options

#### Additional Features
- Settings screen
- Data export/import
- Cloud backup
- Dark mode
- Sharing items

## Usage Tips

### Taking Good Photos
- Use good lighting
- Center the item in frame
- Capture unique details
- Take multiple angles

### Organizing Tips
- Create specific lists (e.g., "Christmas Ornaments" instead of just "Decorations")
- Use consistent type names (e.g., always use "ornament" not "ornament" and "decoration")
- Add descriptions for unique details
- Keep values updated for insurance purposes

### Best Practices
- Regularly update your lists
- Take photos immediately when you get new items
- Use descriptive names
- Backup your data periodically (export feature coming soon)

## Keyboard Shortcuts (Desktop)

When running on desktop:
- **Ctrl/Cmd + R**: Hot reload during development
- **Shift + R**: Hot restart

## Troubleshooting

### App won't start
**Solution**: Run `flutter clean` then `flutter pub get` and try again

### Photos not saving
**Solution**: 
- Check permissions (camera and storage)
- On Android: Settings > Apps > Organizer > Permissions
- On iOS: Settings > Organizer > Allow Camera and Photos

### Database issues
**Solution**: Uninstall the app and reinstall it (this will reset the database)

### Items not showing
**Solution**: 
1. Pull down to refresh
2. Check if the list is empty
3. Navigate back to home and re-enter the list

### Camera not working
**Solution**:
- Ensure device has a camera
- Check app permissions
- Try using "Choose from Gallery" instead

## Development Mode

### Hot Reload
When running the app in debug mode:
- Press **'r'** in the terminal for hot reload
- Press **'R'** for hot restart
- Press **'q'** to quit

### Viewing Logs
```bash
flutter logs
```

### Running Tests
```bash
flutter test
```

## Platform-Specific Notes

### Android
- Minimum SDK: Android 5.0 (API 21)
- Recommended: Android 10+ for best experience
- Permissions automatically requested on first use

### iOS
- Minimum version: iOS 12.0
- Requires Xcode 13+ for building
- Permissions requested on first camera/gallery access

## Example Workflow

### Scenario: Shopping for Christmas Ornaments
1. **Before Shopping**: 
   - Open your "Christmas Ornaments" list
   - Review what you already have
   - Notice you have 15 red ornaments but only 3 blue ones

2. **At the Store** (future feature):
   - See a pretty ornament
   - Open the app and take a photo
   - AI tells you if you have something similar
   - Make an informed purchase decision

3. **After Purchase**:
   - Add the new ornament to your list
   - Take clear photos
   - Record the price and year
   - Notes about where you bought it in description

## Data Storage

### Where is my data stored?
- **Database**: Local SQLite database on your device
- **Photos**: Stored in app's private directory
- **Security**: All data stays on your device (no cloud sync yet)

### Data Size Considerations
- Each photo is stored at full resolution
- Consider this if you have hundreds of items
- Future versions will include image compression

## Performance Tips

### For Best Performance
- Close and reopen the app if it feels slow
- Don't add too many photos per item (3-5 is ideal)
- Use shorter descriptions
- Restart your device if issues persist

## Next Steps

Now that you're set up:
1. ✅ Create your first lists
2. ✅ Add some items with photos
3. ✅ Explore sorting and organizing
4. ✅ Edit and update items as needed
5. 🔜 Wait for AI features in the next update!

## Need Help?

### Documentation
- [README.md](README.md) - Project overview
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Technical architecture
- [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) - UI/UX guidelines
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - Development workflow
- [AI_INTEGRATION.md](AI_INTEGRATION.md) - AI implementation plan
- [SETUP_COMPLETE.md](SETUP_COMPLETE.md) - What's been built

### Common Questions

**Q: Can I use this without internet?**  
A: Yes! Everything works offline. No internet required.

**Q: How many items can I store?**  
A: Practically unlimited. Performance depends on your device.

**Q: Can I export my data?**  
A: Not yet, but this feature is planned.

**Q: Does this use cloud storage?**  
A: No, everything is stored locally on your device.

**Q: When will AI features be ready?**  
A: AI-powered duplicate detection is planned for the next development phase.

---

**Enjoy organizing your collections!** 📦✨

Start by running `flutter run` and create your first list!
