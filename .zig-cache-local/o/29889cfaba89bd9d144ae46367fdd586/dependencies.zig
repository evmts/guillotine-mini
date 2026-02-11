pub const packages = struct {
    pub const @"../voltaire" = struct {
        pub const build_root = "/Users/williamcory/guillotine-mini/../voltaire";
        pub const build_zig = @import("../voltaire");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "zbench", "zbench-0.11.2-YTdc7zolAQDlBF9i0ywXIvDjafL3Kg27S-aFUq6dU5zy" },
            .{ "clap", "clap-0.11.0-oBajB03nAQAvaRnlqid3PwE7E_JqPypon6NQoMlm9ekb" },
            .{ "z_ens_normalize", "z_ens_normalize-0.0.0-Iv6nMI2_AgCrLtEnZZnoeP87kZtP-36iIWzj3cD3v-vd" },
            .{ "libwally_core", "../voltaire/packages/voltaire-zig/lib/libwally-core" },
        };
    };
    pub const @"../voltaire/packages/voltaire-zig/lib/libwally-core" = struct {
        pub const available = true;
        pub const build_root = "/Users/williamcory/guillotine-mini/../voltaire/packages/voltaire-zig/lib/libwally-core";
        pub const build_zig = @import("../voltaire/packages/voltaire-zig/lib/libwally-core");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"clap-0.11.0-oBajB03nAQAvaRnlqid3PwE7E_JqPypon6NQoMlm9ekb" = struct {
        pub const build_root = ".zig-cache-global/p/clap-0.11.0-oBajB03nAQAvaRnlqid3PwE7E_JqPypon6NQoMlm9ekb";
        pub const build_zig = @import("clap-0.11.0-oBajB03nAQAvaRnlqid3PwE7E_JqPypon6NQoMlm9ekb");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"z_ens_normalize-0.0.0-Iv6nMI2_AgCrLtEnZZnoeP87kZtP-36iIWzj3cD3v-vd" = struct {
        pub const build_root = ".zig-cache-global/p/z_ens_normalize-0.0.0-Iv6nMI2_AgCrLtEnZZnoeP87kZtP-36iIWzj3cD3v-vd";
        pub const build_zig = @import("z_ens_normalize-0.0.0-Iv6nMI2_AgCrLtEnZZnoeP87kZtP-36iIWzj3cD3v-vd");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"zbench-0.11.2-YTdc7zolAQDlBF9i0ywXIvDjafL3Kg27S-aFUq6dU5zy" = struct {
        pub const build_root = ".zig-cache-global/p/zbench-0.11.2-YTdc7zolAQDlBF9i0ywXIvDjafL3Kg27S-aFUq6dU5zy";
        pub const build_zig = @import("zbench-0.11.2-YTdc7zolAQDlBF9i0ywXIvDjafL3Kg27S-aFUq6dU5zy");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "primitives", "../voltaire" },
    .{ "guillotine_primitives", "../voltaire" },
};
