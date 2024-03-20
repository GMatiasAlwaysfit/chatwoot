import { throwErrorMessage } from 'dashboard/store/utils/api';
import * as MutationHelpers from 'shared/helpers/vuex/mutationHelpers';
import types from '../mutation-types';
import SlaAPI from '../../api/sla';

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
  getSla(_state) {
    return _state.records;
  },
  getUIFlags(_state) {
    return _state.uiFlags;
  },
};

const actions = {
  getSla: async function getSla({ commit }) {
    commit(types.SET_SLA_UI_FLAG, { fetchingList: true });
    try {
      const response = await SlaAPI.get();
      commit(types.SET_SLA, response.data);
      commit(types.SET_SLA_UI_FLAG, { fetchingList: false });
    } catch (error) {
      commit(types.SET_SLA_UI_FLAG, { fetchingList: false });
    }
  },

  createSla: async function createSla({ commit }, slaObj) {
    commit(types.SET_SLA_UI_FLAG, { creatingItem: true });
    try {
      const response = await SlaAPI.create(slaObj);
      commit(types.ADD_SLA, response.data);
      commit(types.SET_SLA_UI_FLAG, { creatingItem: false });
      return response.data;
    } catch (error) {
      commit(types.SET_SLA_UI_FLAG, { creatingItem: false });
      return throwErrorMessage(error);
    }
  },

  updateSla: async function updateSla({ commit }, { id, ...slaObj }) {
    commit(types.SET_SLA_UI_FLAG, { updatingItem: true });
    try {
      const response = await SlaAPI.update(id, slaObj);
      commit(types.EDIT_SLA, response.data);
      commit(types.SET_SLA_UI_FLAG, { updatingItem: false });
      return response.data;
    } catch (error) {
      commit(types.SET_SLA_UI_FLAG, { updatingItem: false });
      return throwErrorMessage(error);
    }
  },

  deleteSla: async function deleteSla({ commit }, id) {
    commit(types.SET_SLA_UI_FLAG, { deletingItem: true });
    try {
      await SlaAPI.delete(id);
      commit(types.DELETE_SLA, id);
      commit(types.SET_SLA_UI_FLAG, { deletingItem: false });
    } catch (error) {
      commit(types.SET_SLA_UI_FLAG, { deletingItem: false });
    }
  },
};

export const mutations = {
  [types.SET_SLA_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },

  [types.SET_SLA]: MutationHelpers.set,
  [types.ADD_SLA]: MutationHelpers.create,
  [types.EDIT_SLA]: MutationHelpers.update,
  [types.DELETE_SLA]: MutationHelpers.destroy,
};

export default {
  namespaced: true,
  actions,
  state,
  getters,
  mutations,
};
