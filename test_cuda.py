import torch

assert torch.cuda.is_available(), "CUDA not available"


print(f"-> GPU: {torch.cuda.get_device_name(0)}.")
print(f"-> PyTorch version: {torch.__version__}.")
print(f"-> PyTorch CUDA version: {torch.version.cuda}.")
print(f"-> PyTorch CUDA arch list: {torch.cuda.get_arch_list()}.")
