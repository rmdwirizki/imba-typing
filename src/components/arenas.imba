export tag app-arenas
	prop resources

	def localize key
		return @resources[data:options:language][key]
	
	prop typer
	prop inactiveLines
	prop activeLines
	prop currentWord
	prop words

	prop counts
	prop input
	prop timer # interval

	def mount 
		@input = document.querySelector('input')

	def build 
		@resources = {
			'en': { 'start-button': 'Start Typing' },
			'id': { 'start-button': 'Mulai Mengetik' }
		}
		@counts = {
			'wrongWords'  : 0,
			'correctWords': 0,
			'correctChars': 0
		}

	def focus
		# Set focus when thread become idle
		setTimeout(&, 100) do
			@input:focus()

	def load url
		const res = await window.fetch url
		return res.json

	def start
		# Get json url

		const urlChunks = window:location:href:split('/')
		const lastChunk = urlChunks[urlChunks:length - 1]
		
		if lastChunk == '' || lastChunk:indexOf('.') != -1
			urlChunks:pop()

		const url = urlChunks:join('/') + '/dist/data/words-' + data:options:language + '.json'

		# Get json data

		@words = await self.load url 
		self.shuffleWords(@words)

		# Reset variabel and statistics

		@activeLines = @words
		@inactiveLines = [{wrong: false, word: ''}]
		
		@currentWord = @activeLines[0]
		@typer = ''

		@counts:wrongWords   = 0
		@counts:correctWords = 0
		@counts:correctChars = 0

		# Start the game

		data:countdown = data:options:duration
		data:playing = true

		self.focus
		self.countingDown
				
	def stop
		data:playing = false
		clearInterval @timer

	def countingDown
		@timer = setInterval(&, 500) do
			# Update statistics

			const finishedWords = @counts:wrongWords + @counts:correctWords
			const elapsedTimes  = data:options:duration - data:countdown

			const acc = (finishedWords == 0) ? 0 : (@counts:correctWords / finishedWords) * 100
			const wpm = (elapsedTimes  == 0) ? 0 : (60 * @counts:correctWords) / elapsedTimes
			const cpm = (elapsedTimes  == 0) ? 0 : (60 * @counts:correctChars) / elapsedTimes

			data:stats:acc = Math:ceil(acc)
			data:stats:wpm = Math:ceil(wpm)
			data:stats:cpm = Math:ceil(cpm)
      
			# Start countdown every seconds

			if data:countdown > 0
				data:countdown -= 0.5
			else
				self.stop

			Imba.commit

	def typing e
		# If typing alphabet
		if e:_event:keyCode >= 65 && e:_event:keyCode <= 90
			const currentKey = e:_event:key
			const nextChar   = @activeLines[0]:charAt(0)
			const prevIndex  = @inactiveLines:length - 1
			const nextWord   = @activeLines[0]
			const prevWord   = @inactiveLines[prevIndex]:word
			
			let isWrong = false

			if currentKey == nextChar && self.isMatch
				@activeLines[0] = nextWord:substr(1)
			else
				isWrong = true
			
			@inactiveLines[prevIndex] = { wrong: isWrong, word: prevWord + currentKey }

	def spacing
		const prevIndex = @inactiveLines:length - 1
		const nextWord  = @activeLines[0]
		const prevWord  = @inactiveLines[prevIndex]:word

		# Don't process
		if prevWord == '' && nextWord == @currentWord
			return;
		
		# Wrong 
		if prevWord != @currentWord 
			@inactiveLines[prevIndex]:wrong = true
			@counts:wrongWords++
		
		# Correct 
		else 
			@counts:correctWords++
			@counts:correctChars += @currentWord:length
		
		# Get new words to type
		@inactiveLines:push({ wrong: false, word: ''})
		@activeLines:shift()
		
		@currentWord = @activeLines[0]

	def backspacing
		const prevIndex = @inactiveLines:length - 1
		const nextWord  = @activeLines[0]
		const prevWord  = @inactiveLines[prevIndex]:word

		if self.isMatch
			@activeLines[0] = prevWord:slice(-1) + nextWord
		
		@inactiveLines[prevIndex]:word = prevWord:slice(0, -1)
		@inactiveLines[prevIndex]:wrong = !self.isMatch

		@typer = ''

	def isMatch
		return @inactiveLines[@inactiveLines:length - 1]:word + @activeLines[0] == @currentWord

	# Helper. Fish-Yates algorithm

	def shuffleWords array
		let count = array:length, randomnumber, temp
		while count
			randomnumber = Math.random() * count-- | 0
			temp = array[count]
			array[count] = array[randomnumber]
			array[randomnumber] = temp

	def render
		<self> 
			<div.arena .is-playing=(data:playing) :click.focus>
				<div.left.block>
					<div.line>
						for item in inactiveLines
							<span.word .is-wrong=(item:wrong)> item:word
				<input[typer] :keydown.typing :keydown.space.spacing :keydown.del.backspacing type="text" autofocus="autofocus">
				<div.right.block>
					<div.line>
						for item in activeLines
							<span.word> item
			<div.block>
				<div.play.button :click.start>
					localize('start-button')
