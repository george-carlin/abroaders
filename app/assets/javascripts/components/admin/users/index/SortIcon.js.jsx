var SortIcon = React.createClass({
  propTypes: {
    status: React.PropTypes.string.isRequired,
  },

  render() {
    var className;
    switch(this.props.status) {
      case "asc":
        className = "fa fa-chevron-down";
        break;
      case "desc":
        className = "fa fa-chevron-up";
        break;
    };

    var style = this.props.status == "hidden" ? { display: "none" } : {};

    return <i className={className} style={style} />
  }
});
