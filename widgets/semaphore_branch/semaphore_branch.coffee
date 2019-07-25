class Dashing.SemaphoreBranch extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    $(@node).removeClass('failed pending passed');
    $(@node).addClass(data['status'])