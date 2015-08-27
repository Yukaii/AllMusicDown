import React from 'react';

import $ from 'jquery'
import _ from 'underscore'

import polyfill from 'es6-promise';
import 'isomorphic-fetch';

import Infinite from 'react-infinite';

var Album = React.createClass({

  getInitialState: function() {
    return {
      isExpanded: false
    }
  },

  expandDetail: function() {
    this.setState({ isExpanded: !this.state.isExpanded });
  },

  render: function() {
    var album = this.props.album;

    var albumStyle = {
      summary: {
        whiteSpace: 'pre-wrap'
      },
      detail: {

      },
      expanded: {
        display: 'block'
      }
    }

    return(
      <div className="album">
        <img src={ album.cover_img } />
        <h3>{ album.title }</h3>
        <a onClick={ this.expandDetail }>{ this.state.isExpanded ? 'Less' : 'More' }</a>
        <div className="album-detail" style={
          _.extend( {},
            albumStyle.detail,
            { display: 'none' },
            this.state.isExpanded && albumStyle.expanded)
          }>
          <div className="album-summary" style={ albumStyle.summary }>
            { album.summary }
          </div>
          <ul>
            { _.values(album.direct_links).map((link) => {
                return(
                  <li>
                    <a href={ link }>{ link }</a>
                  </li>
                )
              })
            }
          </ul>
        </div>
      </div>
    );

  }
})

export default class AlbumCollection extends React.Component {
  // 竟然不是 implement getInitialState e04
  constructor(props) {
    super(props);
    this.state = { albumList: props.initialList };
  }

  componentDidMount() {
    fetch('/entries').then((response) => {
      return response.json();
    }).then((albumList) => {
      this.setState({albumList: albumList});
    })
  }

  render() {
    var albumNodes = this.state.albumList.map( (album) => {
      return(
        <Album album={album} />
      )
    });

    return(
      <div>
        { albumNodes }
      </div>
    );
  }
}
// AlbumCollection.propTypes = {  };
AlbumCollection.defaultProps = { initialList: [] };
