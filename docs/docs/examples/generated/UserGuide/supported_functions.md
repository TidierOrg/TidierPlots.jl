


```julia
using TidierPlots
using DataFrames
using PalmerPenguins
using WGLMakie
```


<a id='@geom_bar,-@labs'></a>

<a id='@geom_bar,-@labs-1'></a>

## @geom_bar, @labs


```julia
WGLMakie.activate!()
penguins = dropmissing(DataFrame(PalmerPenguins.load()))
ggplot(data = penguins) +
    geom_bar(@aes(x = species)) +
    labs(x = "Species")
```

<div id="22dccc1a-84ee-4d83-b002-1417911dec59" data-jscall-id="subsession-application-dom">
  <div>
    <div></div>
  </div>
  <div style="width: 100%; height: 100%" data-jscall-id="15">
    <script type="module">    JSServe.lock_loading(() => {
        return JSServe.fetch_binary('jsserve/bin/a961066a925f142764600fb673b2f1452c75bee7-16241633840806002620.bin').then(msgs=> JSServe.init_session('22dccc1a-84ee-4d83-b002-1417911dec59', msgs, 'sub'));
    })
</script>
    <canvas style="display: block" data-jscall-id="16" tabindex="0"></canvas>
  </div>
</div>

---


*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

