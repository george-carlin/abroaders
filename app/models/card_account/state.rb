class CardAccount::State < Struct.new(:status, :reconsidered)
  include CardAccount::StatusReaders

  GRAPH = {
    ["recommended", false] => [
      ["clicked", false],
      ["declined", false],
      ["open",     false],
      ["pending", false],
      ["denied", false],
    ],

    ["clicked", false] => [
      ["clicked", false],
      ["declined", false],
      ["open", false],
      ["pending", false],
      ["denied", false],
    ],

    ["declined", false] => [],

    ["pending", false] => [
      ["open",    false],
      ["denied",  false],
      ["denied",  true],
      ["open",    true],
      ["pending", true],
    ],

    ["pending", true] => [
      ["open", true],
      ["denied", true],
    ],

    ["denied", false] => [
      ["pending", true],
      ["open", true],
      ["denied", true],
    ],
    ["denied", true]    => [],

    ["open", false]     => [],
    ["open", true]      => [],

    ["closed", false]     => [],
    ["closed", true]      => [],
  }.each_with_object({}) do |(from, to), h|
    key = new(*from)
    h[key] ||= []
    to.each do |(status, reconsidered)|
      state = new(status, reconsidered)
      h[key] << state unless h[key].include?(state)
    end
  end

  alias_method :reconsidered?, :reconsidered

  def initialize(status, reconsidered)
    super

    if !GRAPH.keys.include?(self)
      raise ArgumentError, "invalid state #{inspect}"
    end
  end

  alias_method :reconsidered?, :reconsidered

  def reachable?(other_state)
    GRAPH[self].include?(other_state)
  end

  def inspect
    "#<CardAccount::State #{status}, reconsidered: #{reconsidered}>"
  end

end
