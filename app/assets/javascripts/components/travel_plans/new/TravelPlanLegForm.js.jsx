var TravelPlanLegForm = React.createClass({
  render() {
    var formGroupClass;

    if (this.props.showAddBtn || this.props.showRemoveBtn) {
      formGroupClass = "col-xs-12 col-sm-5 form-group";
    } else {
      formGroupClass = "col-xs-12 col-sm-6 form-group";
    }

    return (
      <div>
        <div className="row">
          <div className={formGroupClass}>
            <label htmlFor="travel_plan_origin_lookup">From: </label>
            <input id="travel_plan_origin_lookup" type="text"
                   autoComplete="off" className="form-control" />
          </div>

          <div className={formGroupClass}>
            <label htmlFor="travel_plan_destination_lookup">To: </label>
            <input id="travel_plan_destination_lookup" type="text"
                   autoComplete="off" className="form-control" />
          </div>

          <div className="col-xs-12 col-sm-2">
            <TravelPlanFormAddLegBtn
              hidden={!this.props.showAddBtn}
              onClickCallback={this.props.addTravelPlanLegCallback}
            />
            <TravelPlanFormRemoveLegBtn
              hidden={!this.props.showRemoveBtn}
              onClickCallback={this.props.removeTravelPlanLegCallback} />
          </div>{/* .col-xs-12.col-sm-1 */}
        </div>{/* .row */}

        <div className="row">
          <DateRangeSelect colClasses={formGroupClass} hidden={false} />
          <DateRangeSelect
            colClasses={formGroupClass}
            hidden={this.props.travelPlanType != "return"} />
        </div>{/* .row */}
      </div>
    )
  }
});
