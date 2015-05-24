#!/usr/bin/ruby

require 'Qt'

class Rect
	def initialize( x, y )
		@x = x
		@y = y
	end

	def up
		@y -= 1
	end
	def down
		@y += 1
	end
	def left
		@x -= 1
	end
	def right
		@x += 1
	end

	def x()
		@x
	end
	def y()
		@y
	end

	def ==( rect )
		rect.x == x and rect.y == y
	end
end

class Okno < Qt::Widget
	def initialize
		super

		setWindowTitle( "Snake in RUBY!" )
		setStyle( Qt::CommonStyle.new )
		resize( 500, 500 )

		init_snake

		show
	end

	def paintEvent( e )
		p = Qt::Painter.new( self )
		min = [ width, height ].min
		p.translate( width/2 - min/2, height/2 - min/2 )
		p.scale( (min-1) / 50.0, (min-1) / 50.0 )
		p.drawRect( 0, 0, @rozmiar, @rozmiar )
		p.fillRect( @owoc.x, @owoc.y, 1, 1, Qt::gray )
		for i in (1..@snake.size()-1)
			p.fillRect( @snake[ i ].x, @snake[ i ].y, 1, 1, Qt::blue )
		end
		p.fillRect( @snake[ 0 ].x, @snake[ 0 ].y, 1, 1, Qt::red )
		p.end()
	end

	def timerEvent( e )
		lastPos = @snake[ 0 ].dup

		case @kierunek
		when Qt::Key_Up
			@snake[ 0 ].up
		when Qt::Key_Down
			@snake[ 0 ].down
		when Qt::Key_Left
			@snake[ 0 ].left
		when Qt::Key_Right
			@snake[ 0 ].right
		end

		if @snake[ 0 ].x < 0 or @snake[ 0 ].y < 0 or @snake[ 0 ].x >= @rozmiar or @snake[ 0 ].y >= @rozmiar
			@snake[ 0 ] = lastPos.dup
			gameOver
			return
		end

		if @snake[ 0 ] == @owoc
			@snake.insert( 1, lastPos )
			nowyOwoc()
		else
			for i in (1..@snake.size()-1)
				lastPos2 = @snake[ i ]
				@snake[ i ] = lastPos
				lastPos = lastPos2
			end
		end

		for i in (1..@snake.size()-1)
			if @snake[ 0 ] == @snake[ i ]
				gameOver
				return
			end
		end

		@canChangeDirection = true

		update
	end

	def keyPressEvent( e )
		if not e.isAutoRepeat and @canChangeDirection
			if ( e.key() == Qt::Key_Up and @kierunek != Qt::Key_Down ) or
				( e.key() == Qt::Key_Down and @kierunek != Qt::Key_Up ) or
				( e.key() == Qt::Key_Left and @kierunek != Qt::Key_Right ) or
				( e.key() == Qt::Key_Right and @kierunek != Qt::Key_Left )
					@kierunek = e.key
					@canChangeDirection = false
			end
		end
	end

	def gameOver
		killTimer( @timerID )
		@timerID = 0
		update
		Qt::MessageBox.information( self, "Kolizja", "Game Over!" )
		init_snake
	end

	def nowyOwoc
		@owoc = Rect.new( rand(0..@rozmiar-1), rand(0..@rozmiar-1) )
	end

	def init_snake
		@canChangeDirection = true
		@kierunek = Qt::Key_Right
		@rozmiar = 50
		@snake = []

		for i in (0..4)
			@snake[ i ] = Rect.new( 14-i, 20 )
		end
		nowyOwoc

		@timerID = startTimer( 100 )
	end
end

app = Qt::Application.new( ARGV )
Okno.new
app.exec
