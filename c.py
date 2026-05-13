import os


def create_feature(feature_name: str):
    base_path = os.path.join("lib", "features", feature_name)

    folders = [
        os.path.join(base_path, "data", "datasources"),
        os.path.join(base_path, "data", "models"),
        os.path.join(base_path, "data", "repositories"),

        os.path.join(base_path, "presentation", "refactor"),
        os.path.join(base_path, "presentation", "screens"),
        os.path.join(base_path, "presentation", "widgets"),
        os.path.join(base_path, "presentation", "bloc"),
    ]

    for folder in folders:
        os.makedirs(folder, exist_ok=True)

    print(f"Feature '{feature_name}' created successfully.")


if __name__ == "__main__":
    feature = input("Enter feature name: ").strip()

    if feature:
        create_feature(feature)
    else:
        print("Feature name cannot be empty.")