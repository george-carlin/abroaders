# For this file to actually be loaded, you'll need to add some custom
# code to the .irbrc file in your home dir.
#
# See http://samuelmullen.com/2010/04/irb-global-local-irbrc/
require 'pathname'

# Defines APP_ROOT:
require File.join(File.expand_path('..', __FILE__), 'lib', 'constants')

$LOAD_PATH << APP_ROOT.join('lib') unless $LOAD_PATH.include?(APP_ROOT.join('lib'))
$LOAD_PATH << APP_ROOT.join('app', 'concepts') unless $LOAD_PATH.include?(APP_ROOT.join('app', 'concepts'))
$LOAD_PATH << APP_ROOT.join('app', 'models') unless $LOAD_PATH.include?(APP_ROOT.join('app', 'models'))
$LOAD_PATH << APP_ROOT.join('app', 'lib') unless $LOAD_PATH.include?(APP_ROOT.join('app', 'lib'))
