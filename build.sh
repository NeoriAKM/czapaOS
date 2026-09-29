mkdir -p bin
nasm -f bin src/boot.asm -o bin/boot.bin
nasm -f bin src/kernel.asm -o bin/kernel.bin
cat bin/boot.bin bin/kernel.bin > czapaos.img
qemu-system-x86_64 -drive format=raw,file=czapaos.img