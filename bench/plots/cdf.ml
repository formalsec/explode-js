open Owl
open Owl_plplot

(* Meh *)
let () =
  let df = Dataframe.of_csv ~sep:',' "fast-vulcan-secbench-results.csv" in
  let df = Dataframe.sort df "rtime" in
  let n = Dataframe.row_num df in

  let rtime = Dataframe.(unpack_float_series @@ get_col_by_name df "rtime") in

  let x = Mat.init n 1 (fun i -> rtime.(i)) in
  let y = Mat.init n 1 (fun i -> (float i +. 1.) /. float n *. 100.) in

  let h = Plot.create "cdf.pdf" in

  Plot.stairs ~spec:[ RGB (70, 130, 180); LineWidth 10.; LineStyle 2 ] ~h x y;

  Plot.set_font_size h 24.;
  Plot.set_pen_size h 8.;
  Plot.set_xlabel h "Time (s)";
  Plot.set_ylabel h "Percentage of finished files [%]";


  Plot.legend_on h ~position:SouthEast [| "FAST" |];
  Plot.output h
