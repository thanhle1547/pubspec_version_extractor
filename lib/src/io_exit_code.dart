/// [Source](https://www.freebsd.org/cgi/man.cgi?query=sysexits).
class IOExitCode {
  /// Command completed successfully.
  static const success = IOExitCode._(0, 'success');

  /// An input file (not a system file) did not exist or was not readable.
  static const noInput = IOExitCode._(66, 'noInput');

  /// A service is unavailable.
  ///
  /// This may occur if a support program or file does not exist. This may also
  /// be used as a catch-all error when something you wanted to do does not
  /// work, but you do not know why.
  static const unavailable = IOExitCode._(69, 'unavailable');

  /// An internal software error has been detected.
  ///
  /// This should be limited to non-operating system related errors as possible.
  static const software = IOExitCode._(70, 'software');

  /// A (user specified) output file cannot be created.
  static const cantCreate = IOExitCode._(73, 'cantCreate');

  /// An error occurred doing I/O on some file.
  static const ioError = IOExitCode._(74, 'ioError');

  /// You did not have sufficient permissions to perform the operation.
  ///
  /// This is not intended for file system problems, which should use [noInput]
  /// or [cantCreate], but rather for higher-level permissions.
  static const noPerm = IOExitCode._(77, 'noPerm');

  /// Something was found in an unconfigured or misconfigured state.
  static const config = IOExitCode._(78, 'config');

  /// Exit code value.
  final int code;

  /// Name of the exit code.
  final String _name;

  const IOExitCode._(this.code, this._name);

  @override
  String toString() => '$_name: $code';
}
