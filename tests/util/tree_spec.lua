require('util.tree')

describe('Tree utils', function()
  local getter = function(n)
    if type(n) == "table" then
      return n.tag
    end
    return n
  end

  local tagonly = function(n)
    if type(n) == "table" then
      return n.tag
    end
  end

  local a_eq_2 = {
    {
      { 'a', tag = 'Id' },
      { 32,  tag = 'Number' },
    },
    tag = 'Set',
  }

  describe('traverses', function()
    local t_eq_0 = {
      {
        {
          { 't', tag = 'Id', },
        },
        {
          { 0, tag = 'Number', },
        },
        tag = 'Local',
      },
    }

    --[[
    function love.update(dt)
      t = t + dt
      if ty > midy then
        debugColor = Color.red
      end
    end
    ]]
    local fun = {
      {
        {
          {
            { 'love',   tag = 'Id', },
            { 'update', tag = 'String', },
            tag = 'Index',
          },
        },
        {
          {
            {
              { 'dt', tag = 'Id', },
            },
            {
              {
                {
                  { 't', tag = 'Id', },
                },
                {
                  {
                    'add',
                    { 't',  tag = 'Id', },
                    { 'dt', tag = 'Id', },
                    tag = 'Op',
                  },
                },
                tag = 'Set',
              },
              {
                {
                  'lt',
                  { 'midy', tag = 'Id', },
                  { 'ty',   tag = 'Id', },
                  tag = 'Op',
                },
                {
                  {
                    {
                      { 'debugColor', tag = 'Id', },
                    },
                    {
                      {
                        { 'Color', tag = 'Id', },
                        { 'red',   tag = 'String', },
                        tag = 'Index',
                      },
                    },
                    tag = 'Set',
                  },
                },
                tag = 'If',
              },
            },
            tag = 'Function',
          },
        },
        tag = 'Set',
      },
    }

    --[[
    for i = 1, 5 do
      x = 2
      y = 3
      z = 4
      f()
    end
    ]]
    local forloop = {
      {
        { 'i', tag = 'Id', },
        { 1,   tag = 'Number', },
        { 5,   tag = 'Number', },
        {
          {
            {
              { 'x', tag = 'Id', },
            },
            {
              { 2, tag = 'Number', },
            },
            tag = 'Set',
          },
          {
            {
              { 'y', tag = 'Id', },
            },
            {
              { 3, tag = 'Number', },
            },
            tag = 'Set',
          },
          {
            {
              { 'z', tag = 'Id', },
            },
            {
              { 4, tag = 'Number', },
            },
            tag = 'Set',
          },
          {
            { 'f', tag = 'Id', }, tag = 'Call',
          },
        },
        tag = 'Fornum',
      },
    }
    -- math.sin(math.pi / 2)
    local sin_over_2 = {
      {
        {
          { 'math', tag = 'Id', },
          { 'sin',  tag = 'String', },
          tag = 'Index',
        },
        {
          'div',
          {
            { 'math', tag = 'Id', },
            { 'pi',   tag = 'String', },
            tag = 'Index',
          },
          { 2, tag = 'Number', },
          tag = 'Op',
        },
        tag = 'Call',
      },
    }

    it('preorder', function()
      local a2_res = {
        'Set',
        'Id',
        'a',
        'Number',
        32,
      }
      local t0_res = {
        'Local',
        'Id',
        't',
        'Number',
        0,
      }

      assert.same(a2_res, Tree.preorder(a_eq_2, getter))
      assert.same(t0_res, Tree.preorder(t_eq_0, getter))

      local fun_r = {
        'Set',
        'Index',
        'Id',
        'love',
        'String',
        'update',
        'Function',
        'Id',
        'dt',
        'Set',
        'Id',
        't',
        'Op',
        'add',
        'Id',
        't',
        'Id',
        'dt',
        'If',
        'Op',
        'lt',
        'Id',
        'midy',
        'Id',
        'ty',
        'Set',
        'Id',
        'debugColor',
        'Index',
        'Id',
        'Color',
        'String',
        'red',
      }

      assert.same(fun_r, Tree.preorder(fun, getter))

      local fun_tags = {
        'Set',
        'Index',
        'Id',
        'String',
        'Function',
        'Id',
        'Set',
        'Id',
        'Op',
        'Id',
        'Id',
        'If',
        'Op',
        'Id',
        'Id',
        'Set',
        'Id',
        'Index',
        'Id',
        'String',
      }

      assert.same(fun_tags, Tree.preorder(fun, tagonly))

      local for_tags = {
        'Fornum',
        'Id',
        'Number',
        'Number',
        'Set',
        'Id',
        'Number',
        'Set',
        'Id',
        'Number',
        'Set',
        'Id',
        'Number',
        'Call',
        'Id',
      }

      assert.same(for_tags, Tree.preorder(forloop, tagonly))

      local sin_tags = {
        'Call',
        'Index',
        'Id',
        'String',
        'Op',
        'Index',
        'Id',
        'String',
        'Number',
      }

      assert.same(sin_tags, Tree.preorder(sin_over_2, tagonly))
    end)
  end)
end)

--[[
{
  1: {
    1: {
      1: {
        1: { 1: 'love', tag: 'Id' },
        2: { 1: 'update', tag: 'String' },
        tag: 'Index'
      }
    },
    2: {
      1: {
        1: {
          1: { 1: 'dt', tag: 'Id' }
        },
        2: {
          1: {
            1: {
              1: { 1: 't', tag: 'Id' }
            },
            2: {
              1: {
                1: 'add',
                2: { 1: 't', tag: 'Id' },
                3: { 1: 'dt', tag: 'Id' },
                tag: 'Op'
              }
            },
            tag: 'Set'
          },
          2: {
            1: {
              1: 'lt',
              2: { 1: 'midy', tag: 'Id' },
              3: { 1: 'ty', tag: 'Id' },
              tag: 'Op'
            },
            2: {
              1: {
                1: {
                  1: { 1: 'debugColor', tag: 'Id' }
                },
                2: {
                  1: {
                    1: { 1: 'Color', tag: 'Id' },
                    2: { 1: 'red', tag: 'String' },
                    tag: 'Index'
                  }
                },
                tag: 'Set'
              }
            },
            tag: 'If'
          }
        },
        tag: 'Function'
      }
    },
    tag: 'Set'
  }
}
]]
