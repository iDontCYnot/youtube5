class Player

  constructor: (replace, @width, @height) ->
    @originalPlayer = replace

    @placeholder = document.createElement("div")
    @placeholder.className = "youtube5placeholder"
    @placeholder.style.width = @width + "px"
    @placeholder.style.height = @height + "px"
    @placeholder.setAttribute "data-clean", "yes" # prevent Feedly from stripping style attributes

    @player = create("div", @placeholder, "youtube5player youtube5loading")
    @player.style.width = "100%"
    @player.style.height = "100%"

    replace.parentNode.replaceChild @placeholder, replace

  initVideo: =>
    @video.currentTime = @meta.startTime if @meta.startTime
    @video.removeEventListener "loadedmetadata", @initVideo, false

  videoReady: =>
    @video.removeEventListener "canplay", @videoReady, false

  injectVideo: (meta) =>
    # don't allow injecting the video twice
    return if @meta
    @meta = meta

    if @meta.error
      @player.className = "youtube5player error"
      @error = create("div", @player, "youtube5error")
      @error.innerHTML = @meta.error
      return

    @video = document.createElement("video")

    # sort formats in order of decreasing width
    @meta.formats.sort (a, b) ->
      b.width - a.width

    closestFormat = null
    minWidthDelta = null
    for format in @meta.formats
      widthDelta = Math.abs(@meta.preferredVideoWidth - format.width)
      if !closestFormat or widthDelta < minWidthDelta
        closestFormat = format
        minWidthDelta = widthDelta

    @video.src = closestFormat.url
    @video.controls = true
    @player.insertBefore @video

    if @meta.autoplay
      @video.autoplay = true

    @video.addEventListener "loadedmetadata", @initVideo, false
    @video.addEventListener "canplay", @videoReady, false
