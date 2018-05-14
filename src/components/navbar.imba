export tag app-navbar
  def changeLanguage lang
    data:options:language = lang

  def render
    <self>
      <a href="https://github.com/rmdwirizki/Imba-Typing-Speed" target="_blank"> 'Source on Github'
      <div.locales .is-playing=(data:playing)>  
        <a.is-active=(data:options:language == 'en')
          :click.changeLanguage('en')> 'EN'
        <a.separator> '|'
        <a.is-active=(data:options:language == 'id')
          :click.changeLanguage('id')> 'ID'