#!/usr/bin/env python3
import os
import sys
import ipaddress

def sort_key(net):
    return (net.version, net.network_address, net.prefixlen)

def collapse_file(file_path):
    print(f"Collapsing: {file_path}")
    
    # Read prefixes
    prefixes = []
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                try:
                    prefixes.append(ipaddress.ip_network(line, strict=False))
                except ValueError as e:
                    print(f"  Warning: failed to parse prefix '{line}': {e}", file=sys.stderr)
    
    if not prefixes:
        return
        
    # Collapse/aggregate IPv4 and IPv6 separately
    ips_v4 = [ip for ip in prefixes if ip.version == 4]
    ips_v6 = [ip for ip in prefixes if ip.version == 6]
    collapsed_v4 = list(ipaddress.collapse_addresses(ips_v4))
    collapsed_v6 = list(ipaddress.collapse_addresses(ips_v6))
    collapsed = collapsed_v4 + collapsed_v6
    
    # Sort
    collapsed.sort(key=sort_key)
    
    # Write back in place
    with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
        for net in collapsed:
            f.write(f"{net}\n")

def main():
    target_dir = sys.argv[1] if len(sys.argv) > 1 else "subnets"
    if not os.path.isdir(target_dir):
        print(f"Error: {target_dir} is not a directory", file=sys.stderr)
        sys.exit(1)
        
    # Walk through the directory and find all .txt files
    for root, _, files in os.walk(target_dir):
        for file in files:
            if file.endswith(".txt"):
                file_path = os.path.join(root, file)
                collapse_file(file_path)

if __name__ == "__main__":
    main()
