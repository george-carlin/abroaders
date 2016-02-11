var DateRangeSelect = React.createClass({

  propTypes: {
    colClasses: React.PropTypes.string.isRequired
  },

  render() {
    return (
      <div className={this.props.colClasses}>
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
