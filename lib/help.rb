module HELP
  module_function

  def help
    [
      '*AWS*',
      '`ec2 create`: provision an aws vm',
      '`ec2 keypair`: retrieves SLAMs aws keypair'
    ].join("\n")
  end
end
