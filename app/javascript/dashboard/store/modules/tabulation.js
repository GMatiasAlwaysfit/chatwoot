import { throwErrorMessage } from 'dashboard/store/utils/api';
import * as MutationHelpers from 'shared/helpers/vuex/mutationHelpers';
import types from '../mutation-types';
import TabulationApi from '../../api/tabulation';

const state = {
  records: [],
  uiFlags: {
    fetchingList: false,
    fetchingItem: false,
    creatingItem: false,
    updatingItem: false,
    deletingItem: false,
  },
};

const getters = {
  getTabulations(_state) {
    return _state.records;
  },
  getUIFlags(_state) {
    return _state.uiFlags;
  },
};

const actions = {
  getTabulations: async function getTabulations({ commit }) {
    commit(types.SET_TABULATION_UI_FLAG, { fetchingList: true });
    try {
      const response = await TabulationApi.get();
      commit(types.SET_TABULATION, response.data);
      commit(types.SET_TABULATION_UI_FLAG, { fetchingList: false });
    } catch (error) {
      commit(types.SET_TABULATION_UI_FLAG, { fetchingList: false });
    }
  },

  createTabulation: async function createTabulation({ commit }, TabulationObj) {
    commit(types.SET_TABULATION_UI_FLAG, { creatingItem: true });
    try {
      const response = await TabulationApi.create(TabulationObj);
      commit(types.ADD_TABULATION, response.data);
      commit(types.SET_TABULATION_UI_FLAG, { creatingItem: false });
      return response.data;
    } catch (error) {
      commit(types.SET_TABULATION_UI_FLAG, { creatingItem: false });
      return throwErrorMessage(error);
    }
  },

  updateTabulation: async function updateTabulation(
    { commit },
    { id, ...TabulationObj }
  ) {
    commit(types.SET_TABULATION_UI_FLAG, { updatingItem: true });
    try {
      const response = await TabulationApi.update(id, TabulationObj);
      commit(types.EDIT_TABULATION, response.data);
      commit(types.SET_TABULATION_UI_FLAG, { updatingItem: false });
      return response.data;
    } catch (error) {
      commit(types.SET_TABULATION_UI_FLAG, { updatingItem: false });
      return throwErrorMessage(error);
    }
  },

  deteteTabulation: async function deleteTabulation({ commit }, id) {
    commit(types.SET_TABULATION_UI_FLAG, { deletingItem: true });
    try {
      await TabulationApi.delete(id);
      commit(types.DELETE_TABULATION, id);
      commit(types.SET_TABULATION_UI_FLAG, { deletingItem: false });
    } catch (error) {
      commit(types.SET_TABULATION_UI_FLAG, { deletingItem: false });
    }
  },
};

export const mutations = {
  [types.SET_TABULATION_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },

  [types.SET_TABULATION]: MutationHelpers.set,
  [types.ADD_TABULATION]: MutationHelpers.create,
  [types.EDIT_TABULATION]: MutationHelpers.update,
  [types.DELETE_TABULATION]: MutationHelpers.destroy,
};

export default {
  namespaced: true,
  actions,
  state,
  getters,
  mutations,
};
