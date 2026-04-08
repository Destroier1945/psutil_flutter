import "dart:ffi";

final class StatVfs extends Struct {
  @Uint64()
  external int f_bsize;
  @Uint64()
  external int f_frsize;
  @Uint64()
  external int f_blocks;
  @Uint64()
  external int f_bfree;
  @Uint64()
  external int f_bavail;
  @Uint64()
  external int f_files;
  @Uint64()
  external int f_ffree;
  @Uint64()
  external int f_favail;
  @Uint64()
  external int f_fsid;
  @Uint64()
  external int f_flag;
  @Uint64()
  external int f_namemax;
  @Uint64()
  external int f_spare1;
  @Uint64()
  external int f_spare2;
  @Uint64()
  external int f_spare3;
}

void main() {
  print("sizeOf<StatVfs>() = ${sizeOf<StatVfs>()}");
}
