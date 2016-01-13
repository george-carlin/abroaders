To start with, follow these guidelines:

https://web-design-weekly.com/2015/01/29/opinionated-guide-react-js-best-practices-conventions/


    React.createClass({

      // Declare standard React functions in this order:
      propTypes: {},
      mixins : [],

      getInitialState: function() {},
      getDefaultProps: function() {},

      componentWillMount : function() {},
      componentWillReceiveProps: function() {},
      componentWillUnmount : function() {},

      // custom functions go here and start with a _
      _parseData : function() {},
      _onSelect : function() {},

      // render goes last
      render : function() {}
    })

