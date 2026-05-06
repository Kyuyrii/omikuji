fn main() {
    println!("cargo:rerun-if-changed=proto/SophonPatch.proto");
    prost_build::compile_protos(&["proto/SophonPatch.proto"], &["proto/"])
        .expect("failed to compile sophon protos");
}
