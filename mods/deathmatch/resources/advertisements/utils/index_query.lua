IndexQuery = {

    from = function (self, table)
        self.table = table

        return self
    end;

    connection = function (self, connection)
        self.connection = connection

        return self
    end;

    setPerPage = function (self, perPage)
        self.perPage = perPage

        return self
    end;

    setPage = function (self, page)
        self.page = page

        self:generateSkipAndTake()

        return self
    end;

    where = function (self, column, operator, value)
        if value == nil then
            value = operator
            operator = '='
        end

        table.insert(self.wheres, {column = column, operator = operator, value = value, boolean = 'and'})
    end;

    orderBy = function (self, column, direction)
        self.orderBy = {column = column, direction = direction}

        return self
    end;

    generateSkipAndTake = function (self)
        self.skip = self.perPage * (self.page - 1)
        self.take = self.perPage
    end;

    getSelectString = function (self)
        return table.concat(self.select, ', ')
    end;

    compileWheres = function (self)
        if #self.wheres > 0 then
            local wheres = {}
            for _, where in ipairs(self.wheres) do
                table.insert(wheres, string.format("`%s` %s ?", where.column, where.operator))
                table.insert(self.bindings, where.value)
            end

            return string.format(" WHERE %s", table.concat(wheres, ' AND ')) -- todo: support other boolean separators than 'AND'
        end

        return ''
    end;

    toSql = function (self)
        -- todo: extract query string setup into mysql grammar class.
        local query = string.format("SELECT %s FROM %s", self:getSelectString(), self.table)

        query = string.format("%s %s", query, self:compileWheres())

        if self.orderBy then
            query = string.format("%s ORDER BY `%s` %s", query, self.orderBy.column, self.orderBy.direction)
        end
        
        if self.page then
            query = string.format("%s LIMIT %s OFFSET %s", query, self.take, self.skip)
        end

        return query
    end;

    getPageCount = function (self)
        local query = string.format("SELECT count(0) AS count FROM %s %s", self.table, self:compileWheres())
        local qh = exports.mysql:getConn(self.connection):query(query, unpack(self.bindings))
        local result = qh:poll(10000)

        self.bindings = {}

        return math.ceil(result[1].count / self.perPage)
    end;

    exec = function (self, closure, ...)
        exports.mysql:getConn(self.connection):query(closure, {...}, self:toSql(), unpack(self.bindings))

        self.bindings = {}
    end;
}

setmetatable(IndexQuery, {
    __call = function ()
        return setmetatable({

            connection = 'mta',
            table = nil,
            select = {'*'},
        
            -- filtering
            wheres = {},
            bindings = {},
        
            -- pagination
            page = nil,
            perPage = nil,
            skip = nil,
            take = nil,
        
            orderBy = nil,

        }, {__index = IndexQuery})
    end
})