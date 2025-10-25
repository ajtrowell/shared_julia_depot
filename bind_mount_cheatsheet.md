# Bind Mount Cheat Sheet

## Preparation
- Ensure the destination directory exists and is empty: `sudo mkdir -p /path/to/target`.

## Create the Bind Mount
- Make the target path mirror the source: `sudo mount --bind /real/source /path/to/target`.
- For mount trees that contain other mounts you also need, use `sudo mount --rbind /real/source /path/to/target`.

## Optional: Read-Only View
- Bind mounts start writable. To remount as read-only after binding:
  1. `sudo mount --bind /real/source /path/to/target`
  2. `sudo mount -o remount,ro,bind /path/to/target`

## Tear Down
- Remove the view when finished: `sudo umount /path/to/target` (use `sudo umount -l` if it is busy).

## Notes
- Bind mounts require mount capabilities (typically root or a user namespace with that privilege).
- After binding, any access to `/path/to/target` sees the same files as `/real/source`, making it useful for sandboxing scenarios.
