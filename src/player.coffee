class Player

  constructor: (replace, @width, @height) ->
    @originalPlayer = replace

    @placeholder = document.createElement("div")
    @placeholder.className = "youtube5placeholder"
    @placeholder.style.width = @width + "px"
    @placeholder.style.height = @height + "px"
    @placeholder.setAttribute "data-clean", "yes" # prevent Feedly from stripping style attributes

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
      return

    @video = document.createElement("video")
    @video.style.width = "100%"
    @video.style.height = "100%"

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
    @placeholder.insertBefore @video

    if @meta.autoplay
      @video.autoplay = true

    @video.addEventListener "loadedmetadata", @initVideo, false
    @video.addEventListener "canplay", @videoReady, false
