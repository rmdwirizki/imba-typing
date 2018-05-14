export tag app-banner
	prop resources

	def localize key
		return @resources[data:options:language][key]

	def build 
		@resources = {
			'en': { 
				'title': 'Typing Speed Test',
				'wpm'  : 'words / min',
				'cpm'  : 'chars / min',
				'acc'  : '% accuracy',
				'time' : 'seconds',
				'game-over': 'Your Final Score'
			},
			'id': { 
				'title': 'Tes Mengetik Cepat',
				'wpm'  : 'kata / menit',
				'cpm'  : 'huruf / menit',
				'acc'  : '% akurasi',
				'time' : 'detik',
				'game-over': 'Skor Akhir Anda'
			},
		}
	
	def render
		<self> 
			if !data:playing && data:countdown == 0
				<div.title> localize('game-over')
			else
				<div.title> localize('title')
			<div.statistics>
				<div.item>
					<div.counter> data:stats:wpm
					<div.label> localize('wpm')
				<div.item>
					<div.counter> data:stats:cpm
					<div.label> localize('cpm')
				<div.item>
					<div.counter> data:stats:acc
					<div.label> localize('acc')
			<div.countdown .is-hidden=(!data:playing && data:countdown == 0)>
				<div.counter> Math:ceil(data:countdown)
				<div.label> localize('time')