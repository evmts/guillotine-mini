/// Ethereum hardfork identifiers.
///
/// Hardforks represent protocol upgrades that change EVM behavior,
/// gas costs, or add new features. Each hardfork builds upon the
/// previous ones, maintaining backward compatibility while adding
/// improvements.
pub const Hardfork = enum {
    /// Original Ethereum launch (July 2015).
    /// Base EVM with fundamental opcodes.
    FRONTIER,
    /// First planned hardfork (March 2016).
    /// Added DELEGATECALL and fixed critical issues.
    HOMESTEAD,
    /// Emergency fork for DAO hack (July 2016).
    /// No EVM changes, only state modifications.
    DAO,
    /// Gas repricing fork (October 2016).
    /// EIP-150: Increased gas costs for IO-heavy operations.
    TANGERINE_WHISTLE,
    /// State cleaning fork (November 2016).
    /// EIP-161: Removed empty accounts.
    SPURIOUS_DRAGON,
    /// Major feature fork (October 2017).
    /// Added REVERT, RETURNDATASIZE, RETURNDATACOPY, STATICCALL.
    BYZANTIUM,
    /// Efficiency improvements (February 2019).
    /// Added CREATE2, shift opcodes, EXTCODEHASH.
    CONSTANTINOPLE,
    /// Quick fix fork (February 2019).
    /// Removed EIP-1283 due to reentrancy concerns.
    PETERSBURG,
    /// Gas optimization fork (December 2019).
    /// EIP-2200: Rebalanced SSTORE costs.
    /// Added CHAINID and SELFBALANCE.
    ISTANBUL,
    /// Difficulty bomb delay (January 2020).
    /// No EVM changes.
    MUIR_GLACIER,
    /// Access list fork (April 2021).
    /// EIP-2929: Gas cost for cold/warm access.
    /// EIP-2930: Optional access lists.
    BERLIN,
    /// Fee market reform (August 2021).
    /// EIP-1559: Base fee and new transaction types.
    /// Added BASEFEE opcode.
    LONDON,
    /// Difficulty bomb delay (December 2021).
    /// No EVM changes.
    ARROW_GLACIER,
    /// Difficulty bomb delay (June 2022).
    /// No EVM changes.
    GRAY_GLACIER,
    /// Proof of Stake transition (September 2022).
    /// Replaced DIFFICULTY with PREVRANDAO.
    MERGE,
    /// Withdrawal enabling fork (April 2023).
    /// EIP-3855: PUSH0 opcode.
    SHANGHAI,
    /// Proto-danksharding fork (March 2024).
    /// EIP-4844: Blob transactions.
    /// EIP-1153: Transient storage (TLOAD/TSTORE).
    /// EIP-5656: MCOPY opcode.
    CANCUN,
    /// Prague-Electra fork (May 2025).
    /// EIP-2537: BLS12-381 precompiles.
    /// EIP-7702: Set EOA account code for one transaction.
    /// EIP-7251: Increase max effective balance.
    /// EIP-7002: Execution layer triggerable exits.
    PRAGUE,
    /// Osaka fork (TBD).
    /// EIP-7883: ModExp gas increase.
    /// EIP-7823: ModExp upper bounds.
    /// EIP-7825: Transaction gas limit cap.
    /// EIP-7934: Block RLP limit.
    OSAKA,

    /// Default hardfork for new chains.
    /// Set to latest stable fork (currently PRAGUE).
    pub const DEFAULT = Hardfork.PRAGUE;

    /// Convert hardfork to its numeric representation for version comparisons
    pub fn toInt(self: Hardfork) u32 {
        return @intFromEnum(self);
    }

    /// Check if this hardfork is at least the specified version
    pub fn isAtLeast(self: Hardfork, target: Hardfork) bool {
        return self.toInt() >= target.toInt();
    }

    /// Check if this hardfork is before the specified version
    pub fn isBefore(self: Hardfork, target: Hardfork) bool {
        return self.toInt() < target.toInt();
    }

    /// Parse hardfork from string name (case-insensitive)
    /// Supports both standard names and common variations
    pub fn fromString(name: []const u8) ?Hardfork {
        const std = @import("std");

        // Handle comparisons like ">=Cancun" or ">Berlin"
        var clean_name = name;
        if (name.len > 0 and (name[0] == '>' or name[0] == '<')) {
            var start: usize = 1;
            if (name.len > 1 and name[1] == '=') {
                start = 2;
            }
            clean_name = name[start..];
        }

        // Case-insensitive comparison
        if (std.ascii.eqlIgnoreCase(clean_name, "Frontier")) return .FRONTIER;
        if (std.ascii.eqlIgnoreCase(clean_name, "Homestead")) return .HOMESTEAD;
        if (std.ascii.eqlIgnoreCase(clean_name, "DAO")) return .DAO;
        if (std.ascii.eqlIgnoreCase(clean_name, "TangerineWhistle")) return .TANGERINE_WHISTLE;
        if (std.ascii.eqlIgnoreCase(clean_name, "SpuriousDragon")) return .SPURIOUS_DRAGON;
        if (std.ascii.eqlIgnoreCase(clean_name, "Byzantium")) return .BYZANTIUM;
        if (std.ascii.eqlIgnoreCase(clean_name, "Constantinople")) return .CONSTANTINOPLE;
        if (std.ascii.eqlIgnoreCase(clean_name, "Petersburg")) return .PETERSBURG;
        if (std.ascii.eqlIgnoreCase(clean_name, "ConstantinopleFix")) return .PETERSBURG; // Alias for Petersburg
        if (std.ascii.eqlIgnoreCase(clean_name, "Istanbul")) return .ISTANBUL;
        if (std.ascii.eqlIgnoreCase(clean_name, "MuirGlacier")) return .MUIR_GLACIER;
        if (std.ascii.eqlIgnoreCase(clean_name, "Berlin")) return .BERLIN;
        if (std.ascii.eqlIgnoreCase(clean_name, "London")) return .LONDON;
        if (std.ascii.eqlIgnoreCase(clean_name, "ArrowGlacier")) return .ARROW_GLACIER;
        if (std.ascii.eqlIgnoreCase(clean_name, "GrayGlacier")) return .GRAY_GLACIER;
        if (std.ascii.eqlIgnoreCase(clean_name, "Merge")) return .MERGE;
        if (std.ascii.eqlIgnoreCase(clean_name, "Paris")) return .MERGE; // Alias for Merge
        if (std.ascii.eqlIgnoreCase(clean_name, "Shanghai")) return .SHANGHAI;
        if (std.ascii.eqlIgnoreCase(clean_name, "Cancun")) return .CANCUN;
        if (std.ascii.eqlIgnoreCase(clean_name, "Prague")) return .PRAGUE;
        if (std.ascii.eqlIgnoreCase(clean_name, "Osaka")) return .OSAKA;

        return null;
    }
};
