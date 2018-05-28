import './styles/appStyles.scss'

import {app-navbar} from './components/navbar.imba'
import {app-banner} from './components/banner.imba'
import {app-arenas} from './components/arenas.imba'

let store = {
  options  : { duration: 60, language: 'en' },
  stats    : { wpm: 0, cpm: 0, acc: 0 }, 
  playing  : false
}
store:countdown = store:options:duration

tag App
  def render
    <self>
      <app-navbar[store]>
      <app-banner[store]>
      <app-arenas[store]>

Imba.mount <App>