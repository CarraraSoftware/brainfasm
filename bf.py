TAPE_SIZE = 1024 * 10
ADDR_STACK_SIZE = 1024 * 10

FILE_NAME = "helloworld.bf"

f = open(FILE_NAME, "r")
src = f.read()
tape = [0 for _ in range(TAPE_SIZE)]
addrs = [None for _ in range(ADDR_STACK_SIZE)]

addrs_idx = 0
ip = 0
dp = 0


while True:
    instr = src[ip]

    match instr:
        case '+': 
            tape[dp] = (tape[dp] + 1) % 255
        case '-': 
            tape[dp] = (tape[dp] - 1) % 255
        case '>': 
            dp = (dp + 1) % TAPE_SIZE
        case '<': 
            dp = (dp - 1) % TAPE_SIZE
        case '.':
            print(chr(tape[dp]), end='')
        case ',': 
            chars = ""
            while not chars:
                chars = input()
            ch = chars[0]
            tape[dp] = ord(ch)
            
        case '[': 
            addrs[addrs_idx] = ip
            addrs_idx += 1
        case ']': 
            assert addrs_idx > 0
            addrs_idx -= 1
            addr = addrs[addrs_idx]
            if tape[dp] > 0: 
                ip = addr
                continue

    ip += 1
    if ip >= len(src): exit(0)

f.close()
