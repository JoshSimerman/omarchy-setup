# Temporary virtual mouse via /dev/uinput: moves right until the cursor reaches target x.
import fcntl, os, struct, subprocess, sys, time
target = int(sys.argv[1])
fd = os.open("/dev/uinput", os.O_WRONLY | os.O_NONBLOCK)
fcntl.ioctl(fd, 0x40045564, 1)     # EV_KEY
fcntl.ioctl(fd, 0x40045565, 0x110) # BTN_LEFT
fcntl.ioctl(fd, 0x40045564, 2)     # EV_REL
fcntl.ioctl(fd, 0x40045566, 0)     # REL_X
fcntl.ioctl(fd, 0x40045566, 1)     # REL_Y
os.write(fd, struct.pack("80sHHHHI", b"claude-test-mouse", 3, 1, 1, 1, 0) + b"\0" * (4 * 64 * 4))
fcntl.ioctl(fd, 0x5501)
time.sleep(1)
def ev(t, c, v): os.write(fd, struct.pack("llHHi", 0, 0, t, c, v))
def x(): return int(subprocess.check_output(["hyprctl", "cursorpos"]).split(b",")[0])
for _ in range(400):
    if x() >= target: break
    ev(2, 0, 2); ev(0, 0, 0); time.sleep(0.01)
print("cursor x", x())
time.sleep(0.2)
fcntl.ioctl(fd, 0x5502); os.close(fd)
