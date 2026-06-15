import os

filepath = r"c:\Users\Admin\Documents\Myjob Space\star_india_ads\lib\features\tasks\views\task_details_screen.dart"
components_dir = r"c:\Users\Admin\Documents\Myjob Space\star_india_ads\lib\features\tasks\components"

os.makedirs(components_dir, exist_ok=True)

with open(filepath, "r", encoding="utf-8") as f:
    lines = f.readlines()

split_idx = -1
for i, line in enumerate(lines):
    if "// ── Gradient AppBar" in line:
        split_idx = i
        break

if split_idx != -1:
    main_content = lines[:split_idx]
    components_content = lines[split_idx:]
    
    # find where imports end
    import_end_idx = 0
    for i in range(len(main_content)):
        if main_content[i].startswith("import "):
            import_end_idx = i
    
    main_content.insert(import_end_idx + 1, "\npart '../components/task_details_components.dart';\n")
    
    components_content.insert(0, "part of '../views/task_details_screen.dart';\n\n")
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.writelines(main_content)
        
    with open(os.path.join(components_dir, "task_details_components.dart"), "w", encoding="utf-8") as f:
        f.writelines(components_content)
        
    print("Successfully split the file.")
else:
    print("Could not find split point.")
