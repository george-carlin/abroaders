module Abroaders::LogoHelper
  def logo
    image_tag(
      'abroaders-logo-white-md.png',
      alt: 'Abroaders - Sign Up',
      size: '250x94',
    )
  end
end
