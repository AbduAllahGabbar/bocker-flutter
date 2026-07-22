# Component Reference Guide

## MyTextButton
**Location:** `lib/core/componants/my_text_button.dart`

### Basic Usage:
```dart
MyTextButton(
  title: "Click Me",
  onPressed: () {
    print("Clicked!");
  },
)
```

### With Custom Color:
```dart
MyTextButton(
  title: "Delete",
  textColor: Colors.red,
  onPressed: () => deleteItem(),
)
```

### With Icon:
```dart
MyTextButton(
  title: "Add",
  icon: Icon(Icons.add),
  onPressed: () => addItem(),
)
```

### Loading State:
```dart
MyTextButton(
  title: "Submitting...",
  isLoading: true,
  onPressed: () => submit(),
)
```

---

## MyDefaultLoader
**Location:** `lib/core/componants/my_default_loader.dart`

### Basic Usage:
```dart
const MyDefaultLoader()
```

### Custom Size and Color:
```dart
MyDefaultLoader(
  size: 40,
  color: Colors.blue,
  strokeWidth: 3,
)
```

---

## MyElevatedSmall
**Location:** `lib/core/componants/my_elevated_small.dart`

### Basic Usage:
```dart
MyElevatedSmall(
  title: "Check",
  onPressed: () => check(),
)
```

### With Custom Colors:
```dart
MyElevatedSmall(
  title: "Retry",
  backgroundColor: Colors.orange,
  foregroundColor: Colors.white,
  onPressed: () => retry(),
)
```

### Loading State:
```dart
MyElevatedSmall(
  title: "Processing...",
  isLoading: true,
  onPressed: () => process(),
)
```

---

## ShimmerExtension
**Location:** `lib/core/utils/shimmer_extension.dart`

### Basic Usage:
```dart
Container(
  width: 100,
  height: 20,
  color: Colors.white,
).applyShimmer()
```

### With Custom Colors:
```dart
Container(
  width: 100,
  height: 20,
  color: Colors.grey,
).applyShimmer(
  baseColor: Colors.grey[400],
  highlightColor: Colors.grey[200],
)
```

### On Any Widget:
```dart
CircleAvatar(
  radius: 30,
  backgroundColor: Colors.white,
).applyShimmer()
```

---

## Import Statements

```dart
// MyTextButton
import 'package:boker/core/componants/my_text_button.dart';

// MyDefaultLoader
import 'package:boker/core/componants/my_default_loader.dart';

// MyElevatedSmall
import 'package:boker/core/componants/my_elevated_small.dart';

// ShimmerExtension
import 'package:boker/core/utils/shimmer_extension.dart';

// MyElevatedButton (previously created)
import 'package:boker/core/componants/my_elevated_button.dart';
```

