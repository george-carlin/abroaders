function DateRangeSelect(props) {
  return (
    <div className={props.colClasses}>
      <div id="travel_plan_daterange_select"
            className="input-daterange input-group">
        <span className="input-group-addon">Between</span>
        <input type="text" className="form-control" name="start" />
        <span className="input-group-addon">and</span>
        <input type="text" className="form-control" name="end" />
      </div>
    </div>
  );
};

DateRangeSelect.propTypes = { colClasses: React.PropTypes.string.isRequired };
