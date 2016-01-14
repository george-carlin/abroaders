var NewTravelPlan = React.createClass({
  getInitialState() {
    return {
      type: "return",
      legs: [ {} ]
    }
  },


  _addTravelPlanLeg() {
    // TODO add an upper limit on the number of legs (at the server level too!)
    existingLegs = this.state.legs;
    existingLegs.push({});
    this.setState({ legs: existingLegs });
  },


  _removeTravelPlanLeg(index) {
    existingLegs = this.state.legs;
    existingLegs.splice(index, 1)
    this.setState({ legs: existingLegs });
  },

  
  _showAddLegBtns() {
    return this.state.type == "multicity";
  },


  _showRemoveLegBtns() {
    return this.state.type == "multicity" && this.state.legs.length > 1;
  },


  _didChangeType(e) {
    var newState = { type: e.target.value }

    if (newState.type === "multicity") {
      newState.legs = [{}, {}]
    } else {
      newState.legs = [{}]
    }

    this.setState(newState);
  },


  render() {

    var legs = this.state.legs.map(function (leg, i) {
      return (
        <TravelPlanLegForm
          key={i}
          addTravelPlanLegCallback={this._addTravelPlanLeg}
          removeTravelPlanLegCallback={this._removeTravelPlanLeg.bind(this, i)}
          showAddBtn={this._showAddLegBtns()}
          showRemoveBtn={this._showRemoveLegBtns()}
          travelPlanType={this.state.type}
        />
      )
    }.bind(this));

    return (
      <div>
        <TravelPlanTypeSelect changeTypeCallback={this._didChangeType} />

        {legs}

        <div className="row">
          <div className="col-xs-4">
            <label>No of passengers</label>
            <input type="number" className="form-control" />
          </div>
        </div>
      </div>
    )
  }
});
