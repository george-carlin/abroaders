APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))

EMAIL_REGEXP = /\A[^@\s]+@[^@\s]+\z/

PSQL_MAX_INT = POSTGRESQL_MAX_INT_VALUE = (2**31 - 1)
PSQL_MIN_INT = POSTGRESQL_MIN_INT_VALUE = POSTGRESQL_MAX_INT_VALUE * -1
