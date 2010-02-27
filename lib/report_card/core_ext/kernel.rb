# Really ugly, but needed to make Integrity play nice

module Kernel
  alias_method :real_require, :require
  def require(file)
    return true if file == ".bundle/environment"
    return true if file == "integrity"
    real_require(file)
  end
end