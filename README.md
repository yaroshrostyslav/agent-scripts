Scripts to boost my productivity and AI agents

## Raspberry Pi 5

Setup and utility scripts for Raspberry Pi 5.

### Usage

**1. First run** — enables PCIe 3.0, installs git, enables SSH, then reboots:
```bash
cd ~/sources/
bash scripts/raspberry-pi-5/first-run.sh
```

**2. llama.cpp setup** — run from the directory where you want `blis/` and `llama.cpp/` cloned:
```bash
bash agent-scripts/scripts/raspberry-pi-5/llama.cpp/setup.sh
```

Runs in order: `install.sh` → `models.sh` → `service.sh`

| Script | Description |
|---|---|
| `llama.cpp/install.sh` | Builds BLIS, compiles llama.cpp, installs `llama-cli` and `llama-server` globally |
| `llama.cpp/models.sh` | Downloads Gemma 4 Q4_K_M GGUF model |
| `llama.cpp/service.sh` | Registers llama-server as a systemd service |
| `llama.cpp/start-server.sh` | Starts llama-server manually |
| `ssd-benchmark.sh` | Benchmarks NVMe SSD read/write speed |

**Logs:**
```bash
journalctl -u llama-server -f
sudo systemctl status llama-server
```
