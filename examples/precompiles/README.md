# Call the first nine precompiles

Address a normal EVM message to each precompile on Cancun. SHA-256, RIPEMD-160 and identity receive the three bytes `abc`. MODEXP decodes three length words and computes 2⁵ modulo 13. An invalid ECRECOVER signature illustrates a successful call with empty output. The last four rows exercise the BN254 operations and one BLAKE2F compression round.

Run [the example](main.zig) from the repository root.

```sh
zig build run-precompiles
```

**Expected output**

```text
0x01 ECRECOVER gas=3000 output_bytes=0
0x02 SHA256 gas=72 output_bytes=32
0x03 RIPEMD160 gas=720 output_bytes=32
0x04 IDENTITY gas=18 output_bytes=3
0x05 MODEXP gas=200 output_bytes=1
0x06 BN254ADD gas=150 output_bytes=64
0x07 BN254MUL gas=6000 output_bytes=64
0x08 BN254PAIRING gas=45000 output_bytes=32
0x09 BLAKE2F gas=1 output_bytes=64
```
