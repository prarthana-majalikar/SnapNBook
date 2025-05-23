enum ServiceCategory { vehicle, furniture, electronics, kitchenAppliances }

const categoryLabels = {
  ServiceCategory.vehicle: 'Vehicle',
  ServiceCategory.furniture: 'Furniture',
  ServiceCategory.electronics: 'Electronics',
  ServiceCategory.kitchenAppliances: 'Kitchen Appliances',
};

const categoryItems = {
  ServiceCategory.vehicle: [
    ApplianceItem(key: 'bicycle', displayName: 'Bicycle', price: 100),
    ApplianceItem(key: 'car', displayName: 'Car', price: 100),
    ApplianceItem(key: 'motorcycle', displayName: 'Motorcycle', price: 100),
    ApplianceItem(key: 'bus', displayName: 'Bus', price: 100),
    ApplianceItem(key: 'truck', displayName: 'Truck', price: 100),
    ApplianceItem(key: 'boat', displayName: 'Boat', price: 100),
  ],
  ServiceCategory.furniture: [
    ApplianceItem(key: 'chair', displayName: 'Chair', price: 75),
    ApplianceItem(key: 'couch', displayName: 'Couch', price: 75),
    ApplianceItem(key: 'bed', displayName: 'Bed', price: 75),
    ApplianceItem(key: 'dining table', displayName: 'Dining Table', price: 75),
    ApplianceItem(key: 'toilet', displayName: 'Toilet', price: 75),
  ],
  ServiceCategory.electronics: [
    ApplianceItem(key: 'tv', displayName: 'TV', price: 60),
    ApplianceItem(key: 'laptop', displayName: 'Laptop', price: 60),
    ApplianceItem(key: 'cell phone', displayName: 'Cell Phone', price: 60),
  ],
  ServiceCategory.kitchenAppliances: [
    ApplianceItem(key: 'microwave', displayName: 'Microwave', price: 50),
    ApplianceItem(key: 'oven', displayName: 'Oven', price: 50),
    ApplianceItem(key: 'toaster', displayName: 'Toaster', price: 50),
    ApplianceItem(key: 'sink', displayName: 'Sink', price: 50),
    ApplianceItem(key: 'refrigerator', displayName: 'Refrigerator', price: 50),
    ApplianceItem(key: 'clock', displayName: 'Clock', price: 50),
    ApplianceItem(key: 'hair drier', displayName: 'Hair Drier', price: 50),
  ],
};

class ApplianceItem {
  final String key; // for internal lookup (from object detection)
  final String displayName;
  final int price;

  const ApplianceItem({
    required this.key,
    required this.displayName,
    required this.price,
  });
}

String? getDisplayName(String key) {
  for (var items in categoryItems.values) {
    for (var item in items) {
      if (item.key == key.toLowerCase()) return item.displayName;
    }
  }
  return null;
}

int? getPrice(String key) {
  for (var items in categoryItems.values) {
    for (var item in items) {
      if (item.key == key.toLowerCase()) return item.price;
    }
  }
  return null;
}
