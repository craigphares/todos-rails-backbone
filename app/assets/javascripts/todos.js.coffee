$ ->
	
	# Todo Model
	# ----------
	
	class Todo extends Backbone.Model
		
		defaults:
			title: 'empty todo...'
			done: false

		initialize: ->
			if !@get('title') then @set({ 'title': @defaults.title })
				
		toggle: ->
			@save({ done: !@get('done') })
			
		clear: ->
			@destroy()
			
	# Todo Collection
	# ---------------		
			
	class TodoList extends Backbone.Collection
		
		model: Todo
		
		url: '/todos'
		
		done: ->
			@filter( (todo) -> todo.get('done') )
		
		remaining: ->
			@without.apply(this, @done())
				
	# Create the Todo collection
	todos = new TodoList()
	
	# Todo View
	# ---------
	
	class TodoView extends Backbone.View
		
		tagName: 'li'
		
		todoTemplate: $('#todo-template').html()
		
		events:
			'click .toggle'		: 'toggleDone'
			'dblclick .view'	: 'edit'
			'click a.destroy'	: 'clear'
			'keypress .edit'	: 'updateOnEnter'
			'blur .edit'			: 'close'
			
		initialize: ->
			@model.bind('change', @render, this)
			@model.bind('destroy', @remove, this)
			
		render: ->
			@$el.html(JST['todo'](@model.toJSON()))	
			@$el.toggleClass('done', @model.get('done'))
			@input = @$('.edit')
			this
			
		toggleDone: ->
			@model.toggle()
			
		edit: ->
			@$el.addClass('editing')
			@input.focus()
			
		close: ->
			value = @input.val()
			if !value then @clear()
			@model.save({ title: value })
			@$el.removeClass('editing')
			
		updateOnEnter: (e) ->
			if e.keyCode is 13 then @close()
			
		clear: (e) ->
			@model.clear()
			e.preventDefault()
	
	# App View
	# --------
			
	class AppView extends Backbone.View
		
		el: $('#todoapp')
		
		statsTemplate: $('#stats-template').html()
		
		events:
			'keypress #new-todo'			: 'createOnEnter'
			'click #clear-completed'	: 'clearCompleted'
			'click #toggle-all'				: 'toggleAllComplete'
			
		initialize: ->
			@input = @$('#new-todo')
			@allCheckbox = @$('#toggle-all')[0]
			
			todos.bind('add', @addOne, this)
			todos.bind('reset', @addAll, this)
			todos.bind('all', @render, this)
			
			@footer = @$('footer')
			@main = $('#main')
			
			todos.fetch()
			
		render: ->
			done = todos.done().length
			remaining = todos.remaining().length
			
			if todos.length
				@main.show()
				@footer.show()
				@footer.html(JST['stats']({ done: done, remaining: remaining }))
			else
				@main.hide()
				@footer.hide()
				
			@allCheckbox.checked = !remaining
			this
			
		addOne: (todo) ->
			view = new TodoView({ model: todo })
			@$('#todo-list').append(view.render().el)
			
		addAll: ->
			todos.each(@addOne)
			
		createOnEnter: (e) ->
			if e.keyCode isnt 13 then return
			if !@input.val() then return
			
			todos.create({ title: @input.val() })
			@input.val('')
	
		clearCompleted: ->
			_.each(todos.done(), (todo) -> todo.clear())
			false
			
		toggleAllComplete: ->
			done = @allCheckbox.checked
			todos.each( (todo) -> todo.save({ 'done': done }))
	
	# Create the app
	app = new AppView()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	