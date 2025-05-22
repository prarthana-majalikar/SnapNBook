enum ServiceCategory { transport, furniture, electronics, kitchen }

const categoryLabels = {
  ServiceCategory.transport: 'Transport',
  ServiceCategory.furniture: 'Furniture',
  ServiceCategory.electronics: 'Electronics',
  ServiceCategory.kitchen: 'Kitchen',
};

const categoryItems = {
  ServiceCategory.transport: {
    'bicycle': 100,
    'car': 100,
    'motorcycle': 100,
    'bus': 100,
    'truck': 100,
    'boat': 100,
  },
  ServiceCategory.furniture: {
    'chair': 75,
    'couch': 75,
    'bed': 75,
    'dining table': 75,
    'toilet': 75,
  },
  ServiceCategory.electronics: {'tv': 60, 'laptop': 60, 'cell phone': 60},
  ServiceCategory.kitchen: {
    'microwave': 50,
    'oven': 50,
    'toaster': 50,
    'sink': 50,
    'refrigerator': 50,
    'clock': 50,
    'hair drier': 50,
  },
};
