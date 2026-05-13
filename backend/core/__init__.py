# Core package
#
# Use PyMySQL as the MySQLdb driver so Django's `mysql` engine works without
# the native `mysqlclient` package (which needs a C compiler on Windows).
# Has no effect for non-MySQL backends — purely opt-in.
try:
    import pymysql  # noqa: WPS433
    pymysql.install_as_MySQLdb()
except ImportError:
    pass
