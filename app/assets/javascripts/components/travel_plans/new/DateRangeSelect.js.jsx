var DateRangeSelect = React.createClass({

  propTypes: {
    colClasses: React.PropTypes.string.isRequired,
    hidden:     React.PropTypes.bool
  },

  render() {
    var style = {}
    console.log(this.props.hidden);
    if (this.props.hidden) {
      style.display = "none";
    }

    console.log(JSON.stringify(style));

    return (
      <div className={this.props.colClasses} style={style}>
        <div id="travel_plan_daterange_select"
              className="input-daterange input-group">
          <span className="input-group-addon">Between</span>
          <input type="text" className="form-control" name="start" />
          <span className="input-group-addon">and</span>
          <input type="text" className="form-control" name="end" />
        </div>
      </div>
    )
  }
});
