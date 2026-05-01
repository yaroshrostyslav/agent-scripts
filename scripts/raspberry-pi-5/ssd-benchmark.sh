#!/bin/bash

# Description: SSD Benchmark Script for Raspberry Pi 5
# Requirements: fio (installed automatically if missing)
# Usage:
#   ./ssd-benchmark.sh                        # test file defaults to ~/testfile
#   ./ssd-benchmark.sh /mnt/ssd/testfile      # test file on a mounted SSD
#   ./ssd-benchmark.sh /dev/sda               # test directly on a block device (destructive!)
#
# Example output (Raspberry Pi 5, M.2 2280 256GB NVMe, no SD card):
#   [1/4] Sequential read (SEQ1M QD8)...
#   Read speed: 891MiB/s
#   [2/4] Sequential write (SEQ1M QD8)...
#   Write speed: 867MiB/s
#   [3/4] Random read 4K (RND4K QD1)...
#   Random read 4K speed: 47.7MiB/s
#   [4/4] Random read 4K (RND4K QD64)...
#   Random read 4K QD64 speed: 277MiB/s

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Install fio if not present
if ! command -v fio &> /dev/null; then
    echo -e "${RED}fio is not installed!${NC}"
    echo "Installing fio..."
    sudo apt update && sudo apt install fio -y
fi

# Test file path (first argument or default)
TEST_FILE="${1:-~/testfile}"

echo -e "${GREEN}=== SSD Benchmark ===${NC}"
echo -e "Test file: ${YELLOW}$TEST_FILE${NC}"
echo ""

# Test 1: Sequential read
echo -e "${YELLOW}[1/4] Sequential read (SEQ1M QD8)...${NC}"
sudo fio --name=seq-read --ioengine=libaio --rw=read --bs=1M --iodepth=8 \
  --size=1G --numjobs=1 --runtime=30 --time_based --filename="$TEST_FILE" \
  --direct=1 2>&1 | grep -i "read:" | sed -n 's/.*BW=\([^ (]*\).*/Read speed: \1/p'

echo ""

# Test 2: Sequential write
echo -e "${YELLOW}[2/4] Sequential write (SEQ1M QD8)...${NC}"
sudo fio --name=seq-write --ioengine=libaio --rw=write --bs=1M --iodepth=8 \
  --size=1G --numjobs=1 --runtime=30 --time_based --filename="$TEST_FILE" \
  --direct=1 2>&1 | grep -i "write:" | sed -n 's/.*BW=\([^ (]*\).*/Write speed: \1/p'

echo ""

# Test 3: Random read 4K QD1
echo -e "${YELLOW}[3/4] Random read 4K (RND4K QD1)...${NC}"
sudo fio --name=rand-read-4k --ioengine=libaio --rw=randread --bs=4K --iodepth=1 \
  --size=1G --numjobs=1 --runtime=30 --time_based --filename="$TEST_FILE" \
  --direct=1 2>&1 | grep -i "read:" | sed -n 's/.*BW=\([^ (]*\).*/Random read 4K speed: \1/p'

echo ""

# Test 4: Random read 4K QD64
echo -e "${YELLOW}[4/4] Random read 4K (RND4K QD64)...${NC}"
sudo fio --name=rand-read-qd64 --ioengine=libaio --rw=randread --bs=4K --iodepth=64 \
  --size=1G --numjobs=1 --runtime=30 --time_based --filename="$TEST_FILE" \
  --direct=1 2>&1 | grep -i "read:" | sed -n 's/.*BW=\([^ (]*\).*/Random read 4K QD64 speed: \1/p'

echo ""
echo -e "${GREEN}=== Benchmark complete! ===${NC}"

# Remove test file
sudo rm -f "$TEST_FILE"